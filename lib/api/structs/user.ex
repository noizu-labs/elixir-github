defmodule Noizu.Github.User do
  defstruct [
    :login,
    :id,
    :node_id,
    :avatar_url,
    :gravatar_id,
    :url,
    :html_url,
    :followers_url,
    :following_url,
    :gists_url,
    :starred_url,
    :subscriptions_url,
    :organizations_url,
    :repos_url,
    :events_url,
    :received_events_url,
    :type,
    :site_admin
  ]

  def from_json(nil), do: nil

  def from_json(%{
    login:  login,
    id:  id,
    node_id:  node_id,
    avatar_url:  avatar_url,
    gravatar_id:  gravatar_id,
    url:  url,
    html_url:  html_url,
    followers_url:  followers_url,
    following_url:  following_url,
    gists_url:  gists_url,
    starred_url:  starred_url,
    subscriptions_url:  subscriptions_url,
    organizations_url:  organizations_url,
    repos_url:  repos_url,
    events_url:  events_url,
    received_events_url:  received_events_url,
    type:  type,
    site_admin:  site_admin,
  }) do
    %__MODULE__{
      login: login,
      id: id,
      node_id: node_id,
      avatar_url: avatar_url,
      gravatar_id: gravatar_id,
      url: url,
      html_url: html_url,
      followers_url: followers_url,
      following_url: following_url,
      gists_url: gists_url,
      starred_url: starred_url,
      subscriptions_url: subscriptions_url,
      organizations_url: organizations_url,
      repos_url: repos_url,
      events_url: events_url,
      received_events_url: received_events_url,
      type: type,
      site_admin: site_admin,
    }
  end
end
