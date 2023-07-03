defmodule Noizu.Github.Branches do
  defstruct [
    :branches
  ]

  def from_json(branches) when is_list(branches) do
    branches = Enum.map(branches, &(Noizu.Github.Branch.from_json(&1)))
    %__MODULE__{
      branches: branches
    }
  end
end
