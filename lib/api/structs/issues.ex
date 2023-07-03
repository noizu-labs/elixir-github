defmodule Noizu.Github.Issues do
  defstruct [
    :issues
  ]

  def from_json(issues) when is_list(issues) do
    issues = Enum.map(issues || [], &(Noizu.Github.Issue.from_json(&1)))
    %__MODULE__{
      issues: issues
    }
  end
end
