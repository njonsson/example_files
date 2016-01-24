defmodule ExampleFiles.Util do
  def pluralize(count, singular) when is_integer(count) and
                                      is_binary(singular) do
    pluralize count, singular, "#{singular}s"
  end

  def pluralize(0, singular, plural) when is_binary(singular) and
                                          is_binary(plural) do
    "no #{plural || "#{singular}s"}"
  end

  def pluralize(1, singular, plural) when is_binary(singular) and
                                          is_binary(plural) do
    "1 #{singular}"
  end

  def pluralize(count, singular, plural) when is_integer(count)   and
                                              is_binary(singular) and
                                              is_binary(plural) do
    "#{count} #{plural || "#{singular}s"}"
  end
end
