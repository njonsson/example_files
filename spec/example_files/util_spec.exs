defmodule ExampleFiles.UtilSpec do
  use ESpec, async: true

  # TODO: Figure out why `warn: false` is necessary despite references below that fail to compile without this alias
  alias ExampleFiles.Util, warn: false

  describe ".pluralize" do
    describe ~s(with -1, "foo") do
      subject do: Util.pluralize -1, "foo"

      it do: is_expected.to eq("-1 foos")
    end

    describe ~s(with -1, "ox", "oxen") do
      subject do: Util.pluralize -1, "ox", "oxen"

      it do: is_expected.to eq("-1 oxen")
    end

    describe ~s(with 0, "foo") do
      subject do: Util.pluralize 0, "foo"

      it do: is_expected.to eq("no foos")
    end

    describe ~s(with 0, "ox", "oxen") do
      subject do: Util.pluralize 0, "ox", "oxen"

      it do: is_expected.to eq("no oxen")
    end

    describe ~s(with 1, "foo") do
      subject do: Util.pluralize 1, "foo"

      it do: is_expected.to eq("1 foo")
    end

    describe ~s(with 1, "ox", "oxen") do
      subject do: Util.pluralize 1, "ox", "oxen"

      it do: is_expected.to eq("1 ox")
    end

    describe ~s(with 2, "foo") do
      subject do: Util.pluralize 2, "foo"

      it do: is_expected.to eq("2 foos")
    end

    describe ~s(with 2, "ox", "oxen") do
      subject do: Util.pluralize 2, "ox", "oxen"

      it do: is_expected.to eq("2 oxen")
    end
  end
end
