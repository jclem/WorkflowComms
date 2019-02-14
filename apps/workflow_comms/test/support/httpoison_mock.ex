defmodule WorkflowComms.HTTPoisonMock do
  defmacro post(
             path,
             body,
             status_code \\ Macro.escape(200),
             resp_body \\ Macro.escape(%{"ok" => true})
           ) do
    quote do
      fn unquote(path), unquote(body) ->
        {:ok,
         %HTTPoison.Response{
           status_code: unquote(status_code),
           body: unquote(resp_body)
         }}
      end
    end
  end
end
