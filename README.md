# arsys-ddns
## What's this about?
So you have a domain registered with Arsys?
Great, then you realise the big deal: your ISP gives you a dynamic public IP because you have a
consumer contract and not a business one, which gives you a static public IP.
This means that when, for example, rebooting your router, your public IPv4 and IPv6 prefix
will potentially change, thus breaking your DNS records and making them invalid.

## But DDNS exist!
Yeah, but it sucks:
* **Subdomain Prison**: Most providers lock you into their root domain (mydomain.no-ip.com), preventing you from creating custom records or changing the authoritative nameservers, for example.
* **Black Boxes**: You shouldn't have to rely on closed-source update clients or proprietary router features that may send telemetry or fail silently.
* **Cost & Limitations**: Using your own domain with traditional DDNS often requires a "Pro" subscription, which adds an extra non-sense cost to your DNS domain.

## The solution
Take full control of your domain by interacting **directly** with the Arsys API, schedule this lightweight script to run peridocally in seconds, check for IP changes, and update your domain A and AAAA records only when necessary, **no middlemen required**.

## How to use it
* Clone the repository
* Open [src/main.sh](src/main.sh) and set the needed variables in the `CONFIGURATION` section.
* Save this file and copy it wherever you want to install it, following the Filesystem Hierarchy Standard you should install it in `/usr/local/bin` but its not mandatory.
* Program this script to run periodically with some task scheduler software (cron, systemd, etc.), the update frequency is completely up to you, but I recommend minimum once a day, since it takes minimal resources and execution time you could even run it once per hour if you want to be extremely cautious.
> [!TIP]
> If your system is using systemd (the most common today) the [systemd/](systemd/) directory contains ready-to-use `.service` and `.timer` files to integrate this script seamlessly into your system.
