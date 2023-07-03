defmodule Noizu.Github.Issue do
  defstruct [
    :url,
    :repository_url,
    :labels_url,
    :comments_url,
    :events_url,
    :html_url,
    :id,
    :node_id,
    :number,
    :title,
    :user,
    :labels,
    :state,
    :locked,
    :assignee,
    :assignees,
    :milestone,
    :comments,
    :created_at,
    :updated_at,
    :closed_at,
    :author_association,
    :active_lock_reason,
    :body,
    :reactions,
    :timeline_url,
    :performed_via_github_app,
    :state_reason
  ]

  def from_json(%{
    url: url,
    repository_url: repository_url,
    labels_url:  labels_url,
    comments_url:  comments_url,
    events_url:  events_url,
    html_url:  html_url,
    id:  id,
    node_id:  node_id,
    number:  number,
    title:  title,
    user:  user,
    labels:  labels,
    state:  state,
    locked:  locked,
    assignee:  assignee,
    assignees:  assignees,
    milestone:  milestone,
    comments:  comments,
    created_at:  created_at,
    updated_at:  updated_at,
    closed_at:  closed_at,
    author_association:  author_association,
    active_lock_reason:  active_lock_reason,
    body:  body,
    reactions:  reactions,
    timeline_url:  timeline_url,
    performed_via_github_app:  performed_via_github_app,
    state_reason:  state_reason
  }) do
    assignees = Enum.map(assignees || [], &(Noizu.Github.User.from_json(&1)))
    %__MODULE__{
      url: url,
      repository_url: repository_url,
      labels_url: labels_url,
      comments_url: comments_url,
      events_url: events_url,
      html_url: html_url,
      id: id,
      node_id: node_id,
      number: number,
      title: title,
      user: Noizu.Github.User.from_json(user),
      labels: labels,
      state: state,
      locked: locked,
      assignee: Noizu.Github.User.from_json(assignee),
      assignees: assignees,
      milestone: milestone,
      comments: comments,
      created_at: created_at,
      updated_at: updated_at,
      closed_at: closed_at,
      author_association: author_association,
      active_lock_reason: active_lock_reason,
      body: body,
      reactions: Noizu.Github.Reaction.from_json(reactions),
      timeline_url: timeline_url,
      performed_via_github_app: performed_via_github_app,
      state_reason: state_reason
    }
  end
end
