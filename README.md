# Cloudformation Output Buildkite Plugin

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) for gathering Cloudformation output
and setting as `env` variables

## Gathering Cloudformation Output

```yml
steps:
  - name: Get Output
    plugins:
      - envato/cloudformation-output#v1.0.0:
          output:
            - 'mystack:myoutput:region'
            - 'yourstack:youroutput:region'
```

## Configuration

### `output` (required)

You can use this plugin to return Cloudformation output from AWS and set `env` variables for use by other scripts or plugins.

The returned variable is named the same as your Cloudformation stack output.

Note: Your output names will have `-` replaced with `_` and capitalised, ie, `my-output` will be the `env` var `MY_OUTPUT`.

## License

MIT (see [LICENSE](LICENSE))
