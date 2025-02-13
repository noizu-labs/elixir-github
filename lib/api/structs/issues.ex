defmodule Noizu.Github.Issues do
  defstruct [
    :complete,
    :total,
    :issues,
    :links
  ]


  def format(issue, format)
  def format(issues, format) when is_list(issues) do
    Enum.map(issues, &Noizu.Github.Issue.format(&1, format))
  end
  def format(%__MODULE__{} = this, format) do
    Enum.map(this.issues || [], &Noizu.Github.Issue.format(&1, format))
  end

  
  def from_json(json, headers)
  def from_json(issues, headers) when is_list(issues) do
    issues = Enum.map(issues || [], &(Noizu.Github.Issue.from_json(&1)))
    %__MODULE__{
      complete: true,
      total: length(issues),
      issues: issues,
      links: Noizu.Github.extract_links(headers)
    }
  end

  def from_json(%{total_count: count, incomplete_results: incomplete, items: issues} = a, headers) when is_list(issues) do
    issues = Enum.map(issues || [], &(Noizu.Github.Issue.from_json(&1)))
    %__MODULE__{
      complete: !incomplete,
      total: count,
      issues: issues,
      links: Noizu.Github.extract_links(headers)
    }
  end
end
