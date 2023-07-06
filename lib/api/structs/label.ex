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


  def format(label, format)
  def format(label, format) when is_list(label) do
    Enum.map(label, &format(&1, format))
  end
  def format(nil, _), do: nil
  def format(%__MODULE__{} = this, :basic) do
    %{
      name: this.name,
      color: this.color
    }
  end

  def from_json(v) when is_list(v) do
    Enum.map(v, &from_json(&1))
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
