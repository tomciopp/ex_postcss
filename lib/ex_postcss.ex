defmodule ExPostcss do
  def start(_, _) do
    Supervisor.start_link([], strategy: :one_for_one)
  end

  def run(profile, extra_args) when is_atom(profile) and is_list(extra_args) do 
    config = config_for!(profile)
    config_args = config[:args] || []

    opts = [
      cd: config[:cd] || File.cwd!(),
      env: config[:env] || [{"FORCE_IS_TTY", "true"}],
      into: IO.stream(:stdio, :line),
      stderr_to_stdout: true
    ]

    System.cmd("npx", ["postcss"] ++ config_args ++ extra_args, opts)
    |> elem(1)
  end

  @doc """
  Returns the configuration for the given profile.

  Returns nil if the profile does not exist.
  """
  def config_for!(profile) when is_atom(profile) do
    Application.get_env(:ex_postcss, profile) ||
      raise ArgumentError, """
      unknown ex_postcss profile. Make sure the profile is defined in your config files, such as:

          config :ex_postcss,
            #{profile}: [
              args: ~w(css/app.css -o ../priv/static/assets/app.css --config ./postcss.config.js),
              cd: Path.expand("../assets", __DIR__)
            ]
      """
  end
end
