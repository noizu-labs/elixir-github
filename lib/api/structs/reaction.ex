defmodule Noizu.Github.Reaction do
  defstruct [
    :url,
    :total_count,
    :plus_one,
    :minus_one,
    :laugh,
    :hooray,
    :confused,
    :heart,
    :rocket,
    :eyes
  ]

  def from_json(%{
    :url => url,
    :total_count => total_count,
    :"+1" => plus_one,
    :"-1" => minus_one,
    :laugh => laugh,
    :hooray => hooray,
    :confused => confused,
    :heart => heart,
    :rocket => rocket,
    :eyes => eyes
  }) do
    %__MODULE__{
      url: url,
      total_count: total_count,
      plus_one: plus_one,
      minus_one: minus_one,
      laugh: laugh,
      hooray: hooray,
      confused: confused,
      heart: heart,
      rocket: rocket,
      eyes: eyes
    }
  end
end
