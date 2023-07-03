defmodule Noizu.Github.Api.Branches do

  require Noizu.Github
  import Noizu.Github

  def get(issue_number, options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "repos/#{owner}/#{repo}/branches"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:get, base_url <> query_params, body, Noizu.Github.Branch, options)
  end

  def list(options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "repos/#{owner}/#{repo}/branches"
    state = get_field(:state, options, nil)

    query_options = [state]
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:get, base_url <> query_params, body, Noizu.Github.Branches, options)
  end


end
