ESpec.start

# ESpec.configure fn(config) ->
#   config.before fn ->
#     # {:shared, hello: :world}
#   end
#
#   config.finally fn(_shared) ->
#   end
# end

defmodule Doctest do
  defmacro __using__(_opts) do
    quote do
      __MODULE__ |> to_string
                 |> String.replace(~r/Spec$/, "")
                 |> String.to_atom
                 |> ESpec.DocTest.doctest
    end
  end
end
