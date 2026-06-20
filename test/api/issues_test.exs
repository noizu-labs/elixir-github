defmodule Noizu.Github.Api.IssuesTest do
  use ExUnit.Case
  @moduletag :issues

  # These tests exercise the generated client's decode path: a mocked Finch
  # response is fed through `Noizu.Github.Api.Issues.list_for_repo/1`, which
  # dispatches to the generated `Noizu.Github.Collection.Issue` wrapper and the
  # generated `Noizu.Github.Issue` struct.

  describe "list_for_repo/1" do
    test "decodes a list response into a typed collection with pagination links" do
      options = [state: "open", owner: "noizu-labs", repo: "the-robot-lives", token: "x"]

      Mimic.expect(Finch, :request, fn _req, _name, _opts ->
        {:ok,
         %Finch.Response{
           status: 200,
           body: issues_payload(),
           headers: issues_headers()
         }}
      end)

      {:ok, result} = Noizu.Github.Api.Issues.list_for_repo(options)

      assert %Noizu.Github.Collection.Issue{} = result
      assert result.total == 1
      assert result.complete == true

      assert result.links == %{
               next: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues?page=2",
               last: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues?page=5"
             }

      [issue] = result.items
      assert %Noizu.Github.Issue{} = issue
      assert issue.number == 1
      assert issue.title == "test"
      assert issue.state == "open"
      assert issue.body == "test issue"

      # nested $ref schema is decoded into its generated struct
      assert %Noizu.Github.NullableSimpleUser{login: "noizu", id: 6_298_118} = issue.user
    end
  end

  describe "Noizu.Github.Format" do
    test "projects a generated issue collection into curated :basic views" do
      options = [state: "open", owner: "noizu-labs", repo: "the-robot-lives", token: "x"]

      Mimic.expect(Finch, :request, fn _req, _name, _opts ->
        {:ok, %Finch.Response{status: 200, body: issues_payload(), headers: issues_headers()}}
      end)

      {:ok, result} = Noizu.Github.Api.Issues.list_for_repo(options)

      [basic] = Noizu.Github.Format.format(result, :basic)

      assert basic.id == 1
      assert basic.internal_id == 1_781_365_556
      assert basic.title == "test"
      assert basic.state == "open"
      assert basic.url == "https://github.com/noizu-labs/the-robot-lives/issues/1"
      assert basic.user == %{
               login: "noizu",
               avatar_url: "https://avatars.githubusercontent.com/u/6298118?v=4",
               url: "https://github.com/noizu"
             }

      assert basic.labels == [%{name: "bug", color: "d73a4a"}]
    end

    test "passes unknown shapes through and tolerates nil" do
      assert Noizu.Github.Format.format(nil) == nil
      assert Noizu.Github.Format.format(%{foo: 1}) == %{foo: 1}
      assert Noizu.Github.Format.format("x") == "x"
    end
  end

  def issues_headers() do
    [
      {
        :link,
        """
        <https://api.github.com/repos/noizu-labs/the-robot-lives/issues?page=2>; rel="next",
        <https://api.github.com/repos/noizu-labs/the-robot-lives/issues?page=5>; rel="last"
        """
      }
    ]
  end

  def issues_payload() do
    """
    [
    {
      "url": "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1",
      "repository_url": "https://api.github.com/repos/noizu-labs/the-robot-lives",
      "labels_url": "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/labels{/name}",
      "comments_url": "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/comments",
      "events_url": "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/events",
      "html_url": "https://github.com/noizu-labs/the-robot-lives/issues/1",
      "id": 1781365556,
      "node_id": "I_kwDOJbRdks5qLXs0",
      "number": 1,
      "title": "test",
      "user": {
        "login": "noizu",
        "id": 6298118,
        "node_id": "MDQ6VXNlcjYyOTgxMTg=",
        "avatar_url": "https://avatars.githubusercontent.com/u/6298118?v=4",
        "gravatar_id": "",
        "url": "https://api.github.com/users/noizu",
        "html_url": "https://github.com/noizu",
        "type": "User",
        "site_admin": false
      },
      "labels": [
        {
          "id": 5431772700,
          "node_id": "LA_kwDOJbRdks8AAAABQ8JGHA",
          "url": "https://api.github.com/repos/noizu-labs/the-robot-lives/labels/bug",
          "name": "bug",
          "color": "d73a4a",
          "default": true,
          "description": "Something isn't working"
        }
      ],
      "state": "open",
      "locked": false,
      "assignee": null,
      "assignees": [],
      "milestone": null,
      "comments": 0,
      "created_at": "2023-06-29T19:24:03Z",
      "updated_at": "2023-06-29T19:26:20Z",
      "closed_at": null,
      "author_association": "COLLABORATOR",
      "active_lock_reason": null,
      "body": "test issue",
      "reactions": {
        "url": "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/reactions",
        "total_count": 0,
        "+1": 0,
        "-1": 0,
        "laugh": 0,
        "hooray": 0,
        "confused": 0,
        "heart": 0,
        "rocket": 0,
        "eyes": 0
      },
      "timeline_url": "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/timeline",
      "performed_via_github_app": null,
      "state_reason": null
    }
    ]
    """
  end
end
