defmodule Mix.Tasks.Postcss do
  @moduledoc """
  Invokes postcss with the given args.

  Usage:

      $ mix postcss TASK_OPTIONS PROFILE POSTCSS_ARGS

  Example:

      $ mix postcss default assets/css/app.css priv/static/assets/app.css

  If postcss is not installed, it is automatically downloaded.
  Note the arguments given to this task will be appended
  to any configured arguments.

  ## Options

    * `--runtime-config` - load the runtime configuration before executing
      command

  Note flags to control this Mix task must be given before the profile:

      $ mix postcss --runtime-config default assets/css/app.scss
  """

  @shortdoc "Invokes postcss with the profile and args"

  use Mix.Task

  @impl true
  def run(args) do
    switches = [runtime_config: :boolean]
    {opts, remaining_args} = OptionParser.parse_head!(args, switches: switches)

    if opts[:runtime_config] do
      Mix.Task.run("app.config")
    else
      Application.ensure_all_started(:ex_postcss)
    end

    Mix.Task.reenable("postcss")
    attempt_postcss(remaining_args)
  end

  defp attempt_postcss([profile | args] = all) do
    case ExPostcss.run(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix postcss #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  defp attempt_postcss([]) do
    Mix.raise("`mix postcss` expects the profile as argument")
  end
end
