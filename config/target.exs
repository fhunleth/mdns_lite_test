use Mix.Config

# Authorize the device to receive firmware using your public key.
# See https://hexdocs.pm/nerves_firmware_ssh/readme.html for more information
# on configuring nerves_firmware_ssh.

keys =
  [
    Path.join([System.user_home!(), ".ssh", "id_rsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ecdsa.pub"]),
    Path.join([System.user_home!(), ".ssh", "id_ed25519.pub"])
  ]
  |> Enum.filter(&File.exists?/1)

if keys == [],
  do:
    Mix.raise("""
    No SSH public keys found in ~/.ssh. An ssh authorized key is needed to
    log into the Nerves device and update firmware on it using ssh.
    See your project's config.exs for this error message.
    """)

config :nerves_firmware_ssh,
  authorized_keys: Enum.map(keys, &File.read!/1)

  config :vintage_net,
  regulatory_domain: "US",
  config: [
    {"eth0",
     %{
       type: VintageNet.Technology.Ethernet,
       ipv4: %{
         method: :dhcp
       }
     }},
    {"wlan0",
     %{
       type: VintageNet.Technology.WiFi
     }}
  ]

config :mdns_lite,
  # Use these values to construct the DNS resource record responses
  # to a DNS query.
  mdns_config: %{
    host: :hostname,
    domain: "local",
    ttl: 3600,
    query_types: [
      # IP address lookup,
      :a,
      # Reverse IP lookup
      :ptr,
      # Services - see below
      :srv
    ]
  },
  services: [
    # service type: _http._tcp.local - used in match
    %{
      type: "_http._tcp",
      name: "Web Server",
      protocol: "http",
      transport: "tcp",
      port: 80,
      weight: 0,
      priority: 0
    },
    # service_type: _ssh._tcp.local - used in match
    %{
      type: "_ssh._tcp",
      name: "Secure Socket",
      protocol: "ssh",
      transport: "tcp",
      port: 22,
      weight: 0,
      priority: 0
    }
  ]

# Import target specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# Uncomment to use target specific configurations

# import_config "#{Mix.target()}.exs"
