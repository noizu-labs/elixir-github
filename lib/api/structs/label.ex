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


  def format(issue, format)
  def format(issue, format) when is_list(issue) do
    Enum.map(issue, &format(&1, format))
  end
  def format(%__MODULE__{} = this, :basic) do
    %{
      name: this.name,
      color: this.color
    }
  end

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
