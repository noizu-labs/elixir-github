defmodule Noizu.Github do
  @moduledoc """
  Noizu.Github is a library providing a simple wrapper around Github's API calls.
  It handles various API features such as completions, chat, edit, image generation,
  image editing, image variation, embeddings, audio transcription, audio translation, file management,
  and content moderation.

  ## Configuration

  To configure the library, you need to set the Github API key and optionally,
  the Github organization in your application's configuration:

      config :noizu_github,
        github_api_key: "your_api_key_here",
  """

  #---------------------------------------
  # Global Types
  #---------------------------------------
  @type error_tuple :: {:error, details :: term}

  # option constraints
  @type stream_option() :: boolean

  # Common Type
  @type stream_options() :: %{
                              optional(:stream) => boolean()
                            } | Keyword.t() | nil

  @github_base "https://api.github.com"

  require Logger

  def github_base(), do: @github_base

  def repo_name(options) do
    options[:repo] || Application.get_env(:noizu_github, NoizuLabs.Github.Config)[:repo]
  end

  def repo_owner(options) do
    options[:owner] || Application.get_env(:noizu_github, NoizuLabs.Github.Config)[:owner]
  end



  #-------------------------------
  #
  #-------------------------------
  def generic_stream_provider(callback) do
    fn event, payload ->
      case event do
        {:status, code} -> %{payload | status: code}
        {:headers, headers} -> %{payload | headers: headers}
        {:data, data} ->
          n = String.split(data, "\n\ndata:")
              |> Enum.map(fn data ->
            case Jason.decode(data, keys: :atoms) do
              {:ok, json} ->
                case json do
                  %{:choices => [%{:delta => %{:content => c}, :finish_reason => _} | _]} -> c
                  _ -> nil
                end
              _ -> nil
            end
          end)
              |> Enum.filter(&(&1))
              |> Enum.join("")

          payload = %{payload | message: payload.message <> n}
          callback.(payload) # Call the provided callback function with the payload

        _ -> payload
      end
    end
  end

  #-------------------------------
  #
  #-------------------------------
  @doc """
  A helper function to make API calls to the Github API. This function handles both non-stream and stream API calls.

  ## Parameters

  - type: The HTTP request method (e.g., :get, :post, :put, :patch, :delete)
  - url: The full URL for the API endpoint
  - body: The request body in map format
  - model: The model to be used for the response processing
  - options
    - stream: A boolean value to indicate whether the request should be processed as a stream or not (default: false)
    - raw: return raw response
    - response_log_callback: function(finch) callback for request log.
    - response_log_callback: function(finch, start_ms) callback for response log.

  ## Returns

  Returns a tuple {:ok, response} on successful API call, where response is the decoded JSON response in map format.
  Returns {:error, term} on failure, where term contains error details.

  ## Example

      url = "https://api.github.com/v1/completions"
      body = %{
        prompt: "Once upon a time",
        model: "text-davinci-003",
        max_tokens: 50,
        temperature: 0.7
      }
      {:ok, response} = Noizu.Github.api_call(:post, url, body, Noizu.Github.Completion, stream: false)
  """
  def api_call(type, url, body, model, options \\ nil) do
    stream = options[:stream] || false
    raw = options[:raw] || false
    if stream do
      with {:ok, body} <- body && Jason.encode(body) || {:ok, nil},
           {:ok, r = %{status: 200, message: _}} <- api_call_stream(type, url, body, options) do
        {:ok, r}
        #apply(model, :from_json, [json])
      else
        error ->
          Logger.warning("STREAM API ERROR: \n #{inspect error}")
          error
      end
    else
      with {:ok, body} <- body && Jason.encode(body) || {:ok, nil},
           {:ok, %Finch.Response{status: code, body: body, headers: headers} = response} <- api_call_fetch(type, url, body, options),
           true <- code in 200..299 || {:error, response},
           {:ok, json} <- decode_response(body, raw) do
        unless raw do
          {:ok, apply(model, :from_json, [json, headers])}
        else
          {:ok, apply(model, :from_binary, [json, headers])}
        end

      else
        error ->
          Logger.warning("API ERROR: \n #{inspect error}")
          error
      end
    end
  end

  # Decode a (possibly empty) response body. `204`/`202` and other empty
  # success bodies decode to `nil`; raw requests pass the body through verbatim.
  defp decode_response("", _raw), do: {:ok, nil}
  defp decode_response(nil, _raw), do: {:ok, nil}
  defp decode_response(body, true), do: {:ok, body}
  defp decode_response(body, _raw), do: Jason.decode(body, keys: :atoms)

  #-------------------------------
  #
  #-------------------------------
  def headers(options) do
    token = options[:token] || Application.get_env(:noizu_github, NoizuLabs.Github.Config)[:api_key]
    [
      {"Accept", "application/vnd.github+json"},
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{token}"},
      {"X-GitHub-Api-Version", "2022-11-28"},
    ]
  end

  def extract_links(headers) do
    if links = headers[:link] do
      links
      |> String.split(",")
      |> Enum.map(fn link ->
        [url, rel] = link
                     |> String.trim()
                     |> String.split(";")
        url = String.replace(url, ~r/</, "")
        url = String.replace(url, ~r/>/, "")
        rel = String.replace(rel, ~r/rel="/, "")
        rel = String.replace(rel, ~r/"/, "")
        rel = String.trim(rel)
        rel = %{"last" => :last, "next" => :next, "first" => :first, "prev" => :prev}[rel]
        {rel, String.trim(url)}
      end)
      |> Enum.into(%{})
    else
      %{}
    end
  end
  
  #-------------------------------
  #
  #-------------------------------
  def put_field(body, field, options, default \\ nil)
  def put_field(body, :stream, options, default) do
    flag = options[:stream] && true || default
    Map.put(body, :stream, flag)
  end
  def put_field(body, {field_alias, field}, options, default) do
    if v = options[field_alias] || options[field] || default do
      Map.put(body, field, v)
    else
      body
    end
  end
  def put_field(body, field, options, default) do
    if v = options[field] || default do
      Map.put(body, field, v)
    else
      body
    end
  end


  #-------------------------------
  #
  #-------------------------------
  def get_field(field, options, default \\ nil)
  def get_field({field_alias, field}, options, default) do
    if v = (options[field_alias] || options[field] || default) do
      "#{field}=#{v}"
    end
  end
  def get_field(field, options, default) do
    if v = options[field] || default do
      "#{field}=#{v}"
    end
  end



  #-------------------------------
  #
  #-------------------------------
  defp api_call_fetch(type, url, body, options) do
    ts = :os.system_time(:millisecond)
    request = Finch.build(type, url, headers(options), body)
    |> tap(
         fn(finch) ->
           case options[:request_log_callback] do
             nil -> :nop
             v when is_function(v, 1) -> v.(finch)
             {m,f} -> apply(m, f, [finch])
             _ -> :nop
           end
         end)
      # |> IO.inspect(label: "API_CALL_FETCH", limit: :infinity, printable_limit: :infinity, pretty: true)
    request
    |> Finch.request(Noizu.Github.Finch, [pool_timeout: 600_000, receive_timeout: 600_000])
    |> tap(fn(finch) ->
      case options[:response_log_callback] do
        nil -> :nop
        v when is_function(v, 3) -> v.(finch, request, ts)
        {m,f} -> apply(m, f, [finch, request, ts])
        _ -> :nop
      end
    end)
  end

  #-------------------------------
  #
  #-------------------------------
  defp api_call_stream(type, url, body, options) do
    callback = options[:stream]
    raw = options[:raw]
    ts = :os.system_time(:millisecond)
    request = Finch.build(type, url, headers(options), body)
              |> tap(
                   fn(finch) ->
                     case options[:request_log_callback] do
                       nil -> :nop
                       v when is_function(v, 1) -> v.(finch)
                       {m,f} -> apply(m, f, [finch])
                       _ -> :nop
                     end
                   end)


    request
    |> Finch.stream(Noizu.Github.Finch, %{status: nil, raw: raw, message: ""}, callback, [timeout: 600_000, receive_timeout: 600_000])
    |> tap(fn(finch) ->
      case options[:response_log_callback] do
        nil -> :nop
        v when is_function(v, 3) -> v.(finch, request, ts)
        {m,f} -> apply(m, f, [finch, request, ts])
        _ -> :nop
      end
    end)
  end

  @doc """
  Eagerly fetch all pages of a paginated endpoint, accumulating `:items`.

  Takes a function that accepts an options keyword list and returns
  `{:ok, result}` where `result` has `:items` and `:links` fields (any
  `Collection.*` or `Raw` result), plus the initial options.

  Follows `links[:next]` by incrementing the `:page` option until no next
  link is present. Returns `{:ok, all_items}` or the first `{:error, _}`.

  ## Example

      {:ok, all} = Noizu.Github.paginate(
        &Noizu.Github.Api.Issues.list_for_repo/1,
        state: "open", per_page: 100
      )

  """
  @spec paginate((keyword -> {:ok, term} | {:error, term}), keyword) ::
          {:ok, list} | {:error, term}
  def paginate(fetcher, options \\ []) do
    do_paginate(fetcher, options, 1, [])
  end

  defp do_paginate(fetcher, options, page, acc) do
    opts = Keyword.put(options, :page, page)
    case fetcher.(opts) do
      {:ok, %{items: items, links: links}} ->
        acc = acc ++ items
        if links[:next] do
          do_paginate(fetcher, options, page + 1, acc)
        else
          {:ok, acc}
        end

      {:ok, %{data: _} = raw} ->
        {:ok, acc ++ [raw]}

      {:error, _} = error ->
        error
    end
  end

  @doc """
  Return a lazy `Stream` that yields one `{:ok, result}` per page.

  Each element is the full page result (with `:items`, `:links`, etc.).
  The stream terminates when there is no `:next` link or when the fetcher
  returns an error (the error tuple is yielded as the final element).

  ## Example

      Noizu.Github.stream_pages(
        &Noizu.Github.Api.Issues.list_for_repo/1,
        state: "open", per_page: 100
      )
      |> Enum.flat_map(fn
        {:ok, %{items: items}} -> items
        {:error, _} -> []
      end)

  """
  @spec stream_pages((keyword -> {:ok, term} | {:error, term}), keyword) :: Enumerable.t()
  def stream_pages(fetcher, options \\ []) do
    Stream.resource(
      fn -> 1 end,
      fn
        :halt ->
          {:halt, :done}

        page ->
          opts = Keyword.put(options, :page, page)
          case fetcher.(opts) do
            {:ok, %{links: links} = result} ->
              next = if links[:next], do: page + 1, else: :halt
              {[{:ok, result}], next}

            {:error, _} = error ->
              {[error], :halt}
          end
      end,
      fn _ -> :ok end
    )
  end
end
