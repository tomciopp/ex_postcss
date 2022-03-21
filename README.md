Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/ex_postcss](https://hexdocs.pm/ex_postcss).

# ExPostcss

Mix tasks for installing and invoking [postcss](https://github.com/postcss/postcss-cli).

## Installation

If you are going to build assets in production, then you add
`ex_postcss` as a dependency on all environments but only start it
in dev:

```elixir
def deps do
  [
    {:ex_postcss, "~> 0.1", runtime: Mix.env() == :dev}
  ]
end
```

However, if your assets are precompiled during development,
then it only needs to be a dev dependency:

```elixir
def deps do
  [
    {:ex_postcss, "~> 0.4", only: :dev}
  ]
end
```

## Adding to Phoenix

You must install postcss-cli by running:

```bash
npm i -D postcss postcss-cli
```

You may also want to install additional plugins for the postcss environment
like `autoprefixer`, `postcss-preset-env`, and `cssnano`

```bash
cd assets

npm -i -D autoprefixer postcss-preset-env
```

Next we will add a configuration file for postcss and place it in our assets directory.

```bash
touch assets/postcss.config.js
```

Here's a sample configuration using autoprefixer, postcss-preset-default, and cssnano.

```javascript
module.exports = (ctx) => ({
  plugins: [
    require("autoprefixer"),
    require("postcss-preset-env")({
      stage: 3,
      browsers: [
        "> 0.5% in US",
        "not IE 11",
        "not dead"
      ]
    }),
    require("cssnano")({
      preset: [
        "default", 
        { 
          discardComments: { removeAll: true }
        }
      ]
    })
  ]
})
```

## Profiles

The first argument to `ex_postcss` is the execution profile.
You can define multiple execution profiles with the current
directory, the OS environment, and default arguments to the
`postcss` task:

```elixir
config :ex_postcss, 
  default: [
    args: ~w(css/app.scss -o ../priv/static/assets/app.css --config ./postcss.config.js),
    cd: Path.expand("../assets", __DIR__)
  ]
```

*Note* You must pass in the path to the configuration file for postcss to pick up your plugins.

You can now invoke postcss with:

```bash
$ mix postcss default --no-map
```

When `mix postcss default` is invoked, the task arguments will be appended
to the ones configured above.

## Watching for changes in development

Add the following configuration to your `config/dev.exs` file within the `watchers` section.

```elixir
postcss: {ExPostcss, :run, [:default, ~w(--watch)]}
```

## Usage with `DartSass`

We can combine ex_postcss with DartSass by having dart sass compile to a file in a temporary directory. Postcss can then watch that file and output its contents to the /priv/static directory.

```
config :dart_sass, 
  version: "1.49.9",
  default: [
    args: ~w(css/app.scss ../priv/temp/assets/app.css --load-path=assets/node_modules/),
    cd: Path.expand("../assets", __DIR__)
  ]

config :ex_postcss, 
  default: [
    args: ~w(../priv/temp/assets/app.css -o ../priv/static/assets/app.css --config ./postcss.config.js),
    cd: Path.expand("../assets", __DIR__)
  ]
```

We should ignore this directory in our `.gitconfig` file.

```
# Ignore assets that are produced by build tools.
/priv/temp/
/priv/static/assets/
```

> Note: if you are using esbuild (the default from Phoenix v1.6),
> make sure you remove the `import "../css/app.css"` line at the
> top of assets/js/app.js so `esbuild` stops generating css files.

> Note: make sure the "assets" directory from priv/static is listed
> in the :only option for Plug.Static in your endpoint file at,
> for instance `lib/my_app_web/endpoint.ex`.

In development, we want to enable watch mode. So find the `watchers`
configuration in your `config/dev.exs` and add:

```elixir
  postcss: {ExPostcss, :run, [:default, ~w(--watch)]}
```

Finally, back in your `mix.exs`, make sure you have an `assets.deploy`
alias for deployments:

```elixir
"assets.deploy": [
  "esbuild default --minify",
  "postcss default",
  "phx.digest"
]
```

## Acknowledgements

This package is based on the excellent [esbuild](https://github.com/phoenixframework/esbuild) by Wojtek Mach and José Valim, and [dart_sass](https://github.com/CargoSense/dart_sass) by CargoSense, Inc.

## License

Copyright (c) 2022 Thomas Cioppettini.

ex_postcss source code is licensed under the [MIT License](LICENSE.md).
