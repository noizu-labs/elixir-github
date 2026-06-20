defmodule Noizu.Github.GeneratorTest do
  use ExUnit.Case
  @moduletag :generator

  # Smoke tests over the generated surface. These assert that representative
  # operations, structs and list wrappers were emitted with the expected names
  # and shapes, guarding against silent regressions when the spec is regenerated.

  test "representative API modules and functions exist" do
    for mod <- [
          Noizu.Github.Api.Issues,
          Noizu.Github.Api.Pulls,
          Noizu.Github.Api.Repos,
          Noizu.Github.Api.Meta
        ] do
      Code.ensure_loaded!(mod)
    end

    assert function_exported?(Noizu.Github.Api.Issues, :create, 2)
    assert function_exported?(Noizu.Github.Api.Issues, :get, 2)
    assert function_exported?(Noizu.Github.Api.Issues, :list_for_repo, 1)
    assert function_exported?(Noizu.Github.Api.Pulls, :list, 1)
    assert function_exported?(Noizu.Github.Api.Repos, :get, 1)
    assert function_exported?(Noizu.Github.Api.Meta, :root, 1)
  end

  test "schema structs decode permissively" do
    issue = Noizu.Github.Issue.from_json(%{number: 7, title: "hi", missing: nil})
    assert %Noizu.Github.Issue{number: 7, title: "hi"} = issue

    # missing keys tolerated -> nil, extra keys ignored
    assert Noizu.Github.Issue.from_json(%{}).number == nil
    assert Noizu.Github.Issue.from_json(nil) == nil
  end

  test "list wrappers decode arrays and envelopes" do
    coll = Noizu.Github.Collection.Issue.from_json([%{number: 1}, %{number: 2}], [])
    assert coll.total == 2
    assert [%Noizu.Github.Issue{number: 1}, %Noizu.Github.Issue{number: 2}] = coll.items

    env =
      Noizu.Github.Collection.Issue.from_json(
        %{total_count: 42, incomplete_results: true, items: [%{number: 9}]},
        []
      )

    assert env.total == 42
    assert env.complete == false
  end

  test "every spec operation produced a function" do
    spec =
      Path.join(File.cwd!(), "docs/github-api/api.github.com.json")
      |> File.read!()
      |> Jason.decode!()

    methods = ~w(get put post delete patch)

    spec_op_count =
      for {_path, item} <- spec["paths"],
          {method, op} <- item,
          method in methods,
          is_map(op),
          not is_nil(op["operationId"]),
          reduce: 0 do
        acc -> acc + 1
      end

    generated_op_count =
      Path.wildcard(Path.join(File.cwd!(), "lib/api/*/*.ex"))
      |> Enum.reject(&String.contains?(&1, "/structs/"))
      |> Enum.map(&File.read!/1)
      |> Enum.map(fn src -> length(Regex.scan(~r/^  def /m, src)) end)
      |> Enum.sum()

    assert generated_op_count == spec_op_count
  end
end
