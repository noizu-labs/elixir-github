defmodule Noizu.Github.Label do
  defstruct [
    :id,
    :node_id,
    :url,
    :name,
    :color,
    :default,
    :description
  ]

  def from_json(%{
    :id => id,
    :node_id => node_id,
    :url => url,
    :name => name,
    :color => color,
    :default => default,
    :description => description,
  }) do
    %__MODULE__{
      id: id,
      node_id: node_id,
      url: url,
      name: name,
      color: color,
      default: default,
      description: description,
    }
  end
end
