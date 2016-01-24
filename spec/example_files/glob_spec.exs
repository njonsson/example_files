defmodule ExampleFiles.GlobSpec do
  use ESpec, async: true

  # TODO: Figure out why `warn: false` is necessary despite references below that fail to compile without this alias
  alias ExampleFiles.Glob, warn: false

  describe ".parse" do
    subject do: Glob.parse argument

    describe "with []" do
      let :argument, do: []

      it do: is_expected.to eq("**/*{example,Example,EXAMPLE}*")
    end

    describe ~s(with ["foo"]) do
      let :argument, do: ["foo"]

      it do: is_expected.to eq("foo/*{example,Example,EXAMPLE}*")
    end

    describe ~s(with ["foo", "bar"]) do
      let :argument, do: ["foo", "bar"]

      it do: is_expected.to eq("{foo,bar}/*{example,Example,EXAMPLE}*")
    end

    describe ~s(with "foo") do
      let :argument, do: "foo"

      it do: is_expected.to eq("foo/*{example,Example,EXAMPLE}*")
    end
  end
end
