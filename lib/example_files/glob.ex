defmodule ExampleFiles.Glob do
  def parse([]) do
    "**" |> parse
  end

  def parse([filespec]) when is_binary(filespec) do
    filespec |> parse
  end

  def parse(filespecs) when is_list(filespecs) do
    filespecs_expr = "{#{Enum.join filespecs, ","}}"
    filespecs_expr |> parse
  end

  def parse(filespec) when is_binary(filespec) do
    "#{filespec}/*{example,Example,EXAMPLE}*"
  end
end
