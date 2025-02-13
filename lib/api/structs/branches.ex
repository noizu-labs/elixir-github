defmodule Noizu.Github.Branches do
  defstruct [
    :branches,
    :links
  ]

  def from_json(json, headers)
  def from_json(branches, headers) when is_list(branches) do
    branches = Enum.map(branches, &(Noizu.Github.Branch.from_json(&1)))
    %__MODULE__{
      branches: branches,
      links: Noizu.Github.extract_links(headers)
    }
  end
end
