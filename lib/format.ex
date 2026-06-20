defmodule Noizu.Github.Format do
  @moduledoc """
  Hand-maintained, curated views over generated structs.

  The generated structs under `lib/api/structs/` are full, spec-faithful and
  permissive — great for fidelity, noisy for display. This module layers the
  curated `:basic` projections that the original hand-written client exposed via
  per-struct `format/2` helpers, without touching (or being wiped by) the
  generator.

  Unknown shapes pass through unchanged, so `format/2` is always safe to call.

      Noizu.Github.Format.format(issue)              # => %{id: 1, title: ..., ...}
      Noizu.Github.Format.format(collection, :basic) # => [%{...}, ...]
  """

  alias Noizu.Github.{Issue, Label, SimpleUser, NullableSimpleUser, Collection}

  @type format :: :basic

  @doc "Project a generated struct (or list/collection of them) into a curated view."
  @spec format(term, format) :: term
  def format(value, format \\ :basic)

  def format(nil, _format), do: nil

  def format(list, format) when is_list(list), do: Enum.map(list, &format(&1, format))

  # Collections unwrap to their items.
  def format(%Collection{items: items}, format), do: format(items, format)

  def format(%{__struct__: mod, items: items}, format)
      when mod in [
             Collection.Issue,
             Collection.Label,
             Collection.SimpleUser
           ],
      do: format(items, format)

  def format(%Issue{} = this, :basic) do
    %{
      id: this.number,
      internal_id: this.id,
      url: this.html_url,
      labels: format(this.labels, :basic),
      title: this.title,
      body: this.body,
      state: this.state,
      reactions: this.reactions,
      user: format(this.user, :basic),
      assignee: format(this.assignee, :basic),
      assignees: format(this.assignees, :basic),
      milestone: this.milestone,
      comments: this.comments,
      created_at: this.created_at,
      updated_at: this.updated_at,
      closed_at: this.closed_at
    }
  end

  def format(%SimpleUser{} = this, :basic), do: user_basic(this)
  def format(%NullableSimpleUser{} = this, :basic), do: user_basic(this)

  def format(%Label{} = this, :basic), do: %{name: this.name, color: this.color}

  # `issue.labels` decode to raw maps (the schema's `oneOf[string, object]`).
  def format(%{name: name} = label, :basic) when is_map(label) and not is_struct(label) do
    %{name: name, color: Map.get(label, :color)}
  end

  def format(other, _format), do: other

  defp user_basic(user) do
    %{login: user.login, avatar_url: user.avatar_url, url: user.html_url}
  end
end
