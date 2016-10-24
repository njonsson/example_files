# example_files

[![Travis CI build status]][Travis-CI-build-status]
[![Hex release]           ][Hex-release]

> See what’s changed lately by reading the [project history][project-history].

Some files in a project may be templates for unversioned files, such as
user-specific configuration. The Mix tasks provided here find, copy, and check
the freshness of example files and your copies of them.

## Installation

Use *example_files* by adding it to a Mix `deps` declaration.

```elixir
# mix.exs

def application do
  [applications: [:example_files]]
end

# ...
defp deps do
  [{:example_files, "~> 0.2", only: [:dev, :test]}]
end
# ...
```

## Usage

The *example_files* commands are exposed as Mix tasks. Get help on them through
Mix itself, with `mix help | grep example_files` and `mix help example_files`.

### *example_files* task

To list all example files in your project, `mix example_files`.

This task traverses the current working directory, looking for files that are
intended to serve as explanatory samples of files provided by a project
contributor or user. By default it uses `**/*{example,Example,EXAMPLE}*` as the
file glob pattern.

An example file may be “applied,” which means that it is copied into the same
directory, using a file name that lacks the “example” nomenclature.

```
$ mix example_files
Using glob pattern **/*{example,Example,EXAMPLE}*

Missing:    spec/fixtures/no_collisions/file
1 example file found

Collision detected! spec/fixtures/collisions/file1, corresponding to:
· spec/fixtures/collisions/file1.example
· spec/fixtures/collisions/EXAMPLE-file1
```

### Individual file status

Status is one of three values:

  * Missing — never applied
  * Out-of-date — applied, but currently different in content from the example
  * Up-to-date — applied and identical in content to the example

### Collisions

Your project may contain two or more example files that, when applied, use the
same resulting file name. This constitutes a “collision.” Colliding example files
are noted on _stderr_.

## Contributing

To submit a patch to the project:

1. [Fork][fork-example_files] the official repository.
2. Create your feature branch: `git checkout -b my-new-feature`.
3. Commit your changes: `git commit -am 'Add some feature'`.
4. Push to the branch: `git push origin my-new-feature`.
5. [Create][compare-example_files-branches] a new pull request.

After cloning the repository, `mix deps.get` to install dependencies. Then
`mix espec` to run the tests. You can also `iex` to get an interactive prompt
that will allow you to experiment. To build this package, `mix hex.build`.

To release a new version:

1. Update [the “Installation” section](#installation) of this readme to reference
   the new version, and commit.
2. Update the project history in _History.md_, and commit.
3. Update the version number in _mix.exs_, and commit.
4. Tag the commit and push commits and tags.
5. Build and publish the package on [Hex](Hex-release) with `mix hex.publish`.

## License

Released under the [MIT License][MIT-License].

[Travis CI build status]: https://secure.travis-ci.org/njonsson/example_files.svg?branch=master
[Hex release]:            https://img.shields.io/hexpm/v/example_files.svg

[Travis-CI-build-status]:         http://travis-ci.org/njonsson/example_files                      "Travis CI build status for ‘example_files’"
[Hex-release]:                    https://hex.pm/packages/example_files                            "Hex release of ‘example_files’"
[project-history]:                https://github.com/njonsson/example_files/blob/master/History.md "‘example_files’ project history"
[fork-example_files]:             https://github.com/njonsson/example_files/fork                   "Fork the official repository of ‘example_files’"
[compare-example_files-branches]: https://github.com/njonsson/example_files/compare                "Compare branches of ‘example_files’ repositories"
[MIT-License]:                    http://github.com/njonsson/example_files/blob/master/License.md  "MIT License claim for ‘example_files’"
