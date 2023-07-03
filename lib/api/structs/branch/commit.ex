defmodule Noizu.Github.Branch.Protection do
  defstruct [
    :enabled,
    :required_status_checks
  ]

  def from_json(%{
    enabled: enabled,
    required_status_checks:  required_status_checks
  }) do
    %__MODULE__{
      enabled: enabled,
      required_status_checks: required_status_checks,
    }
  end
end
