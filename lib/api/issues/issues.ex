defmodule Noizu.Github.Api.Issues do

  require Noizu.Github
  import Noizu.Github

  def create(issue, options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "/repos/#{owner}/#{repo}/issues"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = issue
    api_call(:post, base_url <> query_params, body, Noizu.Github.Issue, options)
  end


  def delete(issue, options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "/repos/#{owner}/#{repo}/issues/#{issue}"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:delete, base_url <> query_params, body, Noizu.Github.Issue, options)
  end

  def update(issue_number, update, options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "/repos/#{owner}/#{repo}/issues/#{issue_number}"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = update
    api_call(:patch, base_url <> query_params, body, Noizu.Github.Issue, options)
  end

  def get(issue_number, options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "/repos/#{owner}/#{repo}/issues/#{issue_number}"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:get, base_url <> query_params, body, Noizu.Github.Issue, options)
  end


  def lock(issue_number, options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "/repos/#{owner}/#{repo}/issues/#{issue_number}/lock"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:put, base_url <> query_params, body, Noizu.Github.Issue, options)
  end

  def unlock(issue_number, options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "/repos/#{owner}/#{repo}/issues/#{issue_number}/lock"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:delete, base_url <> query_params, body, Noizu.Github.Issue, options)
  end


  def list(options \\ nil) do
    owner = repo_owner(options)
    repo = repo_name(options)

    base_url = github_base() <> "/repos/#{owner}/#{repo}/issues"
    state = get_field(:state, options, nil)

    query_options = [state]
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:get, base_url <> query_params, body, Noizu.Github.Issues, options)
  end


  def user_issues(options \\ nil) do
    base_url = github_base() <> "/repos/user/issues"
    query_options = []
                    |> Enum.filter(&(&1))
    query_params = (unless query_options == [] do
                      "?" <> Enum.join(query_options, "&")
                    else
                      ""
                    end)
    body = %{}
    api_call(:get, base_url <> query_params, body, Noizu.Github.Issues, options)
  end

end
