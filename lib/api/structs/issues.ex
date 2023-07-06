defmodule Noizu.Github.Issues do
  defstruct [
    :complete,
    :total,
    :issues
  ]


  def format(issue, format)
  def format(issue, format) when is_list(issue) do
    Enum.map(issue, &format(&1, format))
  end
  def format(%__MODULE__{} = this, format) do
    Enum.map(this.issues || [], &Noizu.Github.Issue.format(&1, format))
  end

  def from_json(issues) when is_list(issues) do
    issues = Enum.map(issues || [], &(Noizu.Github.Issue.from_json(&1)))
    %__MODULE__{
      complete: true,
      total: length(issues),
      issues: issues
    }
  end

  def from_json(%{total_count: count, incomplete_results: incomplete, items: issues}) when is_list(issues) do
    issues = Enum.map(issues || [], &(Noizu.Github.Issue.from_json(&1)))
    %__MODULE__{
      complete: !incomplete,
      total: count,
      issues: issues
    }
  end
end
