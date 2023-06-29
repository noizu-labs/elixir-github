defmodule Noizu.Github do
  @moduledoc """
  Noizu.Github is a library providing a simple wrapper around Github's API calls.
  It handles various API features such as completions, chat, edit, image generation,
  image editing, image variation, embeddings, audio transcription, audio translation, file management,
  and content moderation.

  ## Configuration

  To configure the library, you need to set the Github API key and optionally,
  the Github organization in your application's configuration:

      config :noizu_labs_open_ai,
        Github_api_key: "your_api_key_here",
        Github_org: "your_organization_id (optional)"
  """

  #---------------------------------------
  # Global Types
  #---------------------------------------
  @type error_tuple :: {:error, details :: term}

  # option constraints
  @type stream_option() :: boolean
  @type model_option(allowed) :: allowed | String.t
  @type user_option() :: String.t
  @type suffix_option() :: String.t
  @type top_p_option() :: term
  @type max_tokens_option() :: integer
  @type temperature_option() :: float
  @type completions_option() :: integer
  @type log_probability_option() :: float
  @type echo_option() :: term
  @type stop_option() :: term
  @type presence_penalty_option() :: term
  @type frequency_penalty_option() :: term
  @type best_of_option() :: term
  @type logit_bias_option() :: term
  @type language_option() :: String.t()
  @type purpose_option() :: String.t()
  @type response_format_option() :: String.t()
  @type size_option() :: String.t()
  @type mask_option() :: String.t()



  # Common Type
  @type stream_options() :: %{
                              optional(:stream) => boolean()
                            } | Keyword.t() | nil

  @github_base "https://api.github.com/v1/"

  require Logger

  def github_base(), do: @github_base

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
          Logger.warn("STREAM API ERROR: \n #{inspect error}")
          error
      end
    else
      with {:ok, body} <- body && Jason.encode(body) || {:ok, nil},
           {:ok, %Finch.Response{status: 200, body: body}} <- api_call_fetch(type, url, body, options),
           {:ok, json} <- !raw && Jason.decode(body, keys: :atoms) || {:ok, body} do
        unless raw do
          {:ok, apply(model, :from_json, [json])}
        else
          {:ok, apply(model, :from_binary, [json])}
        end

      else
        error ->
          Logger.warn("API ERROR: \n #{inspect error}")
          error
      end
    end
  end

  #-------------------------------
  #
  #-------------------------------
  def headers() do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer #{Application.get_env(:noizu_labs_github, :github_api_key)}"}
    ] |> then(
           fn(headers) ->
             if org = Application.get_env(:noizu_github, :github_org) do
               headers ++ [{"Github-Organization", org}]
             else
               headers
             end
           end
         )
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
  defp api_call_fetch(type, url, body, options) do
    ts = :os.system_time(:millisecond)
    request = Finch.build(type, url, headers(), body)
    |> tap(
         fn(finch) ->
           case request_log_callback = options[:request_log_callback] do
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
      case response_log_callback = options[:response_log_callback] do
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
    request = Finch.build(type, url, headers(), body)
              |> tap(
                   fn(finch) ->
                     case request_log_callback = options[:request_log_callback] do
                       nil -> :nop
                       v when is_function(v, 1) -> v.(finch)
                       {m,f} -> apply(m, f, [finch])
                       _ -> :nop
                     end
                   end)


    request
    |> Finch.stream(Noizu.Github.Finch, %{status: nil, raw: raw, message: ""}, callback, [timeout: 600_000, receive_timeout: 600_000])
    |> tap(fn(finch) ->
      case response_log_callback = options[:response_log_callback] do
        nil -> :nop
        v when is_function(v, 3) -> v.(finch, request, ts)
        {m,f} -> apply(m, f, [finch, request, ts])
        _ -> :nop
      end
    end)
  end
end
