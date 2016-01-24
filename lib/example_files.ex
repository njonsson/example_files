defmodule ExampleFiles do
  @ignored_paths ~w(.git/ _build/ deps/ node_modules/ tmp/)

  def find(filespecs) when is_list(filespecs) do
    glob = filespecs |> ExampleFiles.Glob.parse
    {noncollisions, collisions} = glob |> files
                                       |> Enum.filter(&match?/1)
                                       |> copies
                                       |> partition_by_collision
    {glob, noncollisions, collisions}
  end

  defp copies(examples) when is_list(examples) do
    for example <- examples do
      {status, copy} = ExampleFiles.File.copy?(example)
      {status, example, copy}
    end
  end

  defp files(glob) do
    glob |> Path.wildcard(match_dot: true)
  end

  defp ignored?(path) when is_binary(path) do
    @ignored_paths |> Enum.any?(&(String.starts_with?(path, &1)))
  end

  defp match?(path) when is_binary(path) do
    if ignored?(path) or File.dir?(path) do
      false
    else
      path |> ExampleFiles.File.name_match?
    end
  end

  defp partition_by_collision(copies) when is_list(copies) do
    copies |> Enum.group_by(&elem(&1, 2))
           |> Enum.reduce({[], %{}}, fn({copied_name, copies}, {left, right}) ->
      if length(copies) == 1 do
        {(left ++ copies), right}
      else
        {left,             Map.put(right, copied_name, copies)}
      end
    end)
  end
end
