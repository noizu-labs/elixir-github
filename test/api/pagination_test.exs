defmodule Noizu.Github.PaginationTest do
  use ExUnit.Case
  @moduletag :pagination

  describe "paginate/2" do
    test "collects items across multiple pages and stops when no next link" do
      pages = [
        %{
          items: [%{id: 1}, %{id: 2}],
          links: %{next: "page=2", last: "page=3"},
          total: 2,
          complete: true
        },
        %{
          items: [%{id: 3}, %{id: 4}],
          links: %{next: "page=3", last: "page=3"},
          total: 2,
          complete: true
        },
        %{
          items: [%{id: 5}],
          links: %{last: "page=3"},
          total: 1,
          complete: true
        }
      ]

      fetcher = fn opts ->
        page = Keyword.get(opts, :page, 1)
        {:ok, Enum.at(pages, page - 1)}
      end

      assert {:ok, items} = Noizu.Github.paginate(fetcher, [])
      assert length(items) == 5
      assert Enum.map(items, & &1.id) == [1, 2, 3, 4, 5]
    end

    test "returns single page when no next link" do
      fetcher = fn _opts ->
        {:ok, %{items: [%{id: 1}], links: %{}, total: 1, complete: true}}
      end

      assert {:ok, [%{id: 1}]} = Noizu.Github.paginate(fetcher)
    end

    test "returns error on first page failure" do
      fetcher = fn _opts -> {:error, :boom} end

      assert {:error, :boom} = Noizu.Github.paginate(fetcher)
    end

    test "returns error when a later page fails" do
      fetcher = fn opts ->
        case Keyword.get(opts, :page, 1) do
          1 -> {:ok, %{items: [%{id: 1}], links: %{next: "page=2"}, total: 1, complete: true}}
          2 -> {:error, :page2_failed}
        end
      end

      assert {:error, :page2_failed} = Noizu.Github.paginate(fetcher)
    end
  end

  describe "stream_pages/2" do
    test "yields one {:ok, result} per page then halts" do
      pages = [
        %{items: [%{id: 1}], links: %{next: "page=2"}, total: 1, complete: true},
        %{items: [%{id: 2}], links: %{}, total: 1, complete: true}
      ]

      fetcher = fn opts ->
        page = Keyword.get(opts, :page, 1)
        {:ok, Enum.at(pages, page - 1)}
      end

      results = Noizu.Github.stream_pages(fetcher, []) |> Enum.to_list()

      assert length(results) == 2
      assert [{:ok, p1}, {:ok, p2}] = results
      assert p1.items == [%{id: 1}]
      assert p2.items == [%{id: 2}]
    end

    test "yields error as final element then halts" do
      fetcher = fn opts ->
        case Keyword.get(opts, :page, 1) do
          1 -> {:ok, %{items: [%{id: 1}], links: %{next: "page=2"}, total: 1, complete: true}}
          2 -> {:error, :network_down}
        end
      end

      results = Noizu.Github.stream_pages(fetcher) |> Enum.to_list()
      assert [{:ok, _}, {:error, :network_down}] = results
    end

    test "can be lazily consumed with Enum.take" do
      fetcher = fn opts ->
        page = Keyword.get(opts, :page, 1)
        {:ok, %{items: [%{id: page}], links: %{next: "page=#{page + 1}"}, total: 1, complete: true}}
      end

      [first] = Noizu.Github.stream_pages(fetcher) |> Enum.take(1)
      assert {:ok, %{items: [%{id: 1}]}} = first
    end

    test "flat_map pattern collects all items" do
      pages = [
        %{items: [%{id: 1}, %{id: 2}], links: %{next: "x"}, total: 2, complete: true},
        %{items: [%{id: 3}], links: %{}, total: 1, complete: true}
      ]

      fetcher = fn opts ->
        page = Keyword.get(opts, :page, 1)
        {:ok, Enum.at(pages, page - 1)}
      end

      items =
        Noizu.Github.stream_pages(fetcher)
        |> Enum.flat_map(fn
          {:ok, %{items: items}} -> items
          {:error, _} -> []
        end)

      assert Enum.map(items, & &1.id) == [1, 2, 3]
    end
  end

  describe "paginate/2 with generated decode path (Finch mock)" do
    test "collects typed Issue structs across two pages" do
      base_opts = [state: "open", owner: "noizu-labs", repo: "the-robot-lives", token: "x"]

      Mimic.expect(Finch, :request, fn _req, _name, _opts ->
        {:ok, %Finch.Response{
          status: 200,
          body: issue_page_payload(1),
          headers: issue_page_headers(1, 2)
        }}
      end)
      |> Mimic.expect(:request, fn _req, _name, _opts ->
        {:ok, %Finch.Response{
          status: 200,
          body: issue_page_payload(2),
          headers: issue_page_headers(2, 2)
        }}
      end)

      {:ok, items} = Noizu.Github.paginate(
        &Noizu.Github.Api.Issues.list_for_repo/1,
        base_opts
      )

      assert length(items) == 2
      assert [%Noizu.Github.Issue{number: 1}, %Noizu.Github.Issue{number: 2}] = items
    end
  end

  defp issue_page_headers(page, last_page) do
    if page < last_page do
      [{:link, ~s(<https://api.github.com/issues?page=#{page + 1}>; rel="next", <https://api.github.com/issues?page=#{last_page}>; rel="last")}]
    else
      [{:link, ~s(<https://api.github.com/issues?page=1>; rel="first")}]
    end
  end

  defp issue_page_payload(page) do
    number = page
    """
    [{"number": #{number}, "id": #{number}, "title": "issue #{number}", "state": "open",
      "url": "x", "repository_url": "x", "labels_url": "x", "comments_url": "x",
      "events_url": "x", "html_url": "x", "node_id": "x", "body": "",
      "locked": false, "comments": 0, "created_at": "2023-01-01T00:00:00Z",
      "updated_at": "2023-01-01T00:00:00Z", "author_association": "NONE"}]
    """
  end
end
