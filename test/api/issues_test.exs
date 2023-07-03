
defmodule Noizu.Github.Api.IssuesTest do
  use ExUnit.Case
  @moduletag :issues


  def user(6298118) do
    %Noizu.Github.User{
      login: "noizu",
      id: 6298118,
      node_id: "MDQ6VXNlcjYyOTgxMTg=",
      avatar_url: "https://avatars.githubusercontent.com/u/6298118?v=4",
      gravatar_id: "",
      url: "https://api.github.com/users/noizu",
      html_url: "https://github.com/noizu",
      followers_url: "https://api.github.com/users/noizu/followers",
      following_url: "https://api.github.com/users/noizu/following{/other_user}",
      gists_url: "https://api.github.com/users/noizu/gists{/gist_id}",
      starred_url: "https://api.github.com/users/noizu/starred{/owner}{/repo}",
      subscriptions_url: "https://api.github.com/users/noizu/subscriptions",
      organizations_url: "https://api.github.com/users/noizu/orgs",
      repos_url: "https://api.github.com/users/noizu/repos",
      events_url: "https://api.github.com/users/noizu/events{/privacy}",
      received_events_url: "https://api.github.com/users/noizu/received_events",
      type: "User",
      site_admin: false
    }
  end

  describe "issues/2" do
    test "successful query" do
      options = [state: "open"]
      response = %Noizu.Github.Issues{issues: [
%Noizu.Github.Issue{
  url: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1",
  repository_url: "https://api.github.com/repos/noizu-labs/the-robot-lives",
  labels_url: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/labels{/name}",
  comments_url: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/comments",
  events_url: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/events",
  html_url: "https://github.com/noizu-labs/the-robot-lives/issues/1",
  id: 1781365556,
  node_id: "I_kwDOJbRdks5qLXs0",
  number: 1,
  title: "test",
  user: user(6298118),
  labels: [
    %{color: "d73a4a", default: true, description: "Something isn't working", id: 5431772700, name: "bug", node_id: "LA_kwDOJbRdks8AAAABQ8JGHA", url: "https://api.github.com/repos/noizu-labs/the-robot-lives/labels/bug"},
    %{color: "0075ca", default: true, description: "Improvements or additions to documentation", id: 5431772708, name: "documentation", node_id: "LA_kwDOJbRdks8AAAABQ8JGJA", url: "https://api.github.com/repos/noizu-labs/the-robot-lives/labels/documentation"},
    %{color: "cfd3d7", default: true, description: "This issue or pull request already exists", id: 5431772715, name: "duplicate", node_id: "LA_kwDOJbRdks8AAAABQ8JGKw", url: "https://api.github.com/repos/noizu-labs/the-robot-lives/labels/duplicate"}
  ],
  state: "open",
  locked: false,
  assignee: user(6298118),
  assignees: [user(6298118)],
  milestone: nil,
  comments: 0,
  created_at: "2023-06-29T19:24:03Z",
  updated_at: "2023-06-29T19:26:20Z",
  closed_at: nil,
  author_association: "COLLABORATOR",
  active_lock_reason: nil,
  body: "test issue",
  reactions: %Noizu.Github.Reaction{
    url: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/reactions",
    total_count: 0,
    plus_one: 0,
    minus_one: 0,
    laugh: 0,
    hooray: 0,
    confused: 0,
    heart: 0,
    rocket: 0,
    eyes: 0
  },
  timeline_url: "https://api.github.com/repos/noizu-labs/the-robot-lives/issues/1/timeline",
  performed_via_github_app: nil,
  state_reason: nil
}
      ]}
      Mimic.expect(Finch, :request, fn(_, _, _) -> {:ok, %Finch.Response{status: 200, body: issues_payload()}} end)
      {:ok, result} = Noizu.Github.Api.Issues.issues(options)
      assert response == result
    end
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
      "followers_url": "https://api.github.com/users/noizu/followers",
      "following_url": "https://api.github.com/users/noizu/following{/other_user}",
      "gists_url": "https://api.github.com/users/noizu/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/noizu/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/noizu/subscriptions",
      "organizations_url": "https://api.github.com/users/noizu/orgs",
      "repos_url": "https://api.github.com/users/noizu/repos",
      "events_url": "https://api.github.com/users/noizu/events{/privacy}",
      "received_events_url": "https://api.github.com/users/noizu/received_events",
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
      },
      {
        "id": 5431772708,
        "node_id": "LA_kwDOJbRdks8AAAABQ8JGJA",
        "url": "https://api.github.com/repos/noizu-labs/the-robot-lives/labels/documentation",
        "name": "documentation",
        "color": "0075ca",
        "default": true,
        "description": "Improvements or additions to documentation"
      },
      {
        "id": 5431772715,
        "node_id": "LA_kwDOJbRdks8AAAABQ8JGKw",
        "url": "https://api.github.com/repos/noizu-labs/the-robot-lives/labels/duplicate",
        "name": "duplicate",
        "color": "cfd3d7",
        "default": true,
        "description": "This issue or pull request already exists"
      }
    ],
    "state": "open",
    "locked": false,
    "assignee": {
      "login": "noizu",
      "id": 6298118,
      "node_id": "MDQ6VXNlcjYyOTgxMTg=",
      "avatar_url": "https://avatars.githubusercontent.com/u/6298118?v=4",
      "gravatar_id": "",
      "url": "https://api.github.com/users/noizu",
      "html_url": "https://github.com/noizu",
      "followers_url": "https://api.github.com/users/noizu/followers",
      "following_url": "https://api.github.com/users/noizu/following{/other_user}",
      "gists_url": "https://api.github.com/users/noizu/gists{/gist_id}",
      "starred_url": "https://api.github.com/users/noizu/starred{/owner}{/repo}",
      "subscriptions_url": "https://api.github.com/users/noizu/subscriptions",
      "organizations_url": "https://api.github.com/users/noizu/orgs",
      "repos_url": "https://api.github.com/users/noizu/repos",
      "events_url": "https://api.github.com/users/noizu/events{/privacy}",
      "received_events_url": "https://api.github.com/users/noizu/received_events",
      "type": "User",
      "site_admin": false
    },
    "assignees": [
      {
        "login": "noizu",
        "id": 6298118,
        "node_id": "MDQ6VXNlcjYyOTgxMTg=",
        "avatar_url": "https://avatars.githubusercontent.com/u/6298118?v=4",
        "gravatar_id": "",
        "url": "https://api.github.com/users/noizu",
        "html_url": "https://github.com/noizu",
        "followers_url": "https://api.github.com/users/noizu/followers",
        "following_url": "https://api.github.com/users/noizu/following{/other_user}",
        "gists_url": "https://api.github.com/users/noizu/gists{/gist_id}",
        "starred_url": "https://api.github.com/users/noizu/starred{/owner}{/repo}",
        "subscriptions_url": "https://api.github.com/users/noizu/subscriptions",
        "organizations_url": "https://api.github.com/users/noizu/orgs",
        "repos_url": "https://api.github.com/users/noizu/repos",
        "events_url": "https://api.github.com/users/noizu/events{/privacy}",
        "received_events_url": "https://api.github.com/users/noizu/received_events",
        "type": "User",
        "site_admin": false
      }
    ],
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
