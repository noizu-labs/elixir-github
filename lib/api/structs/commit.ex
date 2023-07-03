defmodule Noizu.Github.Commit do
  defstruct [
    :sha,
    :url
  ]

  def from_json(%{
    sha: sha,
    url:  url
  }) do
    %__MODULE__{
      sha: sha,
      url: url,
    }
  end
end
