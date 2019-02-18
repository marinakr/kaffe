defmodule Kaffe.Config.ProducerTest do
  use ExUnit.Case, async: true

  describe "configuration/0" do
    test "correct settings are extracted" do
      no_sasl_config =
        :kaffe
        |> Application.get_env(:producer)
        |> Keyword.delete(:sasl)

      Application.put_env(:kaffe, :producer, no_sasl_config)

      expected = %{
        endpoints: [kafka: 9092],
        producer_config: [
          auto_start_producers: true,
          allow_topic_auto_creation: false,
          default_producer_config: [
            required_acks: -1,
            ack_timeout: 1000,
            partition_buffer_limit: 512,
            partition_onwire_limit: 1,
            max_batch_size: 1_048_576,
            max_retries: 3,
            retry_backoff_ms: 500,
            compression: :no_compression,
            min_compression_batch_size: 1024
          ]
        ],
        topics: ["kaffe-test"],
        client_name: :kaffe_producer_client,
        partition_strategy: :md5
      }

      assert Kaffe.Config.Producer.configuration() == expected
    end

    test "correct settings with sasl plain are extracted" do
      sasl_config =
        :kaffe
        |> Application.get_env(:producer)
        |> Keyword.put(:sasl, %{mech: :plain, login: "Alice", password: "ecilA"})

      Application.put_env(:kaffe, :producer, sasl_config)

      expected = %{
        endpoints: [kafka: 9092],
        producer_config: [
          auto_start_producers: true,
          allow_topic_auto_creation: false,
          default_producer_config: [
            required_acks: -1,
            ack_timeout: 1000,
            partition_buffer_limit: 512,
            partition_onwire_limit: 1,
            max_batch_size: 1_048_576,
            max_retries: 3,
            retry_backoff_ms: 500,
            compression: :no_compression,
            min_compression_batch_size: 1024
          ],
          sasl: {:plain, "Alice", "ecilA"}
        ],
        topics: ["kaffe-test"],
        client_name: :kaffe_producer_client,
        partition_strategy: :md5
      }

      assert Kaffe.Config.Producer.configuration() == expected
    end
  end

  test "string endpoints parsed correctly" do
    config = Application.get_env(:kaffe, :producer)
    endpoints = Keyword.get(config, :endpoints)

    new_config =
      config
      |> Keyword.delete(:sasl)
      |> Keyword.put(:endpoints, "kafka:9092,localhost:9092")

    Application.put_env(:kaffe, :producer, new_config)

    expected = %{
      endpoints: [kafka: 9092, localhost: 9092],
      producer_config: [
        auto_start_producers: true,
        allow_topic_auto_creation: false,
        default_producer_config: [
          required_acks: -1,
          ack_timeout: 1000,
          partition_buffer_limit: 512,
          partition_onwire_limit: 1,
          max_batch_size: 1_048_576,
          max_retries: 3,
          retry_backoff_ms: 500,
          compression: :no_compression,
          min_compression_batch_size: 1024
        ]
      ],
      topics: ["kaffe-test"],
      client_name: :kaffe_producer_client,
      partition_strategy: :md5
    }

    on_exit(fn ->
      Application.put_env(:kaffe, :producer, Keyword.put(config, :endpoints, endpoints))
    end)

    assert Kaffe.Config.Producer.configuration() == expected
  end
end
