defmodule ExampleFiles.File do
  @name_match_delimited_regex        ~r/(^|\.|_|-)example(\.|_|-|$)/i
  @name_match_camelcase_start_regex  ~r/^[Ee]xample([[:upper:]]|\d|$)/
  @name_match_camelcase_middle_regex ~r/([[:lower:]]|\d)Example([[:upper:]]|\d|$)/

  def copy?(example) when is_binary(example) do
    copy = example |> copy
    status = if File.exists?(copy) do
      if identical?(example, copy) do
        :up_to_date
      else
        :out_of_date
      end
    else
      false
    end
    {status, copy}
  end

  def name_match?(example) when is_binary(example) do
    basename = example |> Path.basename
    not String.match?(basename, ~r/^example$/i) and
      (String.match?(basename, @name_match_delimited_regex)       or
       String.match?(basename, @name_match_camelcase_start_regex) or
       String.match?(basename, @name_match_camelcase_middle_regex))
  end

  defp copy(example) when is_binary(example) do
    dirname  = example |> Path.dirname
    basename = example |> Path.basename
                       |> String.replace(@name_match_delimited_regex,        "")
                       |> String.replace(@name_match_camelcase_start_regex,  "\\1")
                       |> String.replace(@name_match_camelcase_middle_regex, "\\1\\2")
    copy dirname, basename
  end

  defp copy(".", basename) when is_binary(basename) do
    basename
  end

  defp copy(dirname, basename) when is_binary(dirname) and is_binary(basename) do
    Path.join dirname, basename
  end

  defp identical?(file1, file2) when is_binary(file1) and is_binary(file2) do
    {:ok, content1} = File.read(file1)
    {:ok, content2} = File.read(file2)
    content1 == content2
  end
end
