# Env

Provides simple getters for application config, and reads from the sysytem
environment when `{:system, "KEY"}` tuples are present.

## Example

```elixir
case Env.get(:my_app, :secret) do
  {:ok, secret} -> IO.puts "Found a secret"
  {:error, :not_found} -> IO.puts "No secret found"
end
```
