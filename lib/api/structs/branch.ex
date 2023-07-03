defmodule Noizu.Github.Branch do
  defstruct [
    :name,
    :commit,
    :protected,
    :protection,
    :protection_url
  ]

  def from_json(%{
    name: name,
    commit:  commit,
    protected: protected,
    protection: protection,
    protection_url: protection_url
  }) do
    %__MODULE__{
      name: name,
      commit: Noizu.Github.Commit.from_json(commit),
      protected: protected,
      protection: Noizu.Github.Branch.Protection.from_json(commit),
      protection_url: protection_url
    }
  end
end
