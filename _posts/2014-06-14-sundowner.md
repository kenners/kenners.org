---
layout: post
title: "Sundowner"
date: 2014-06-14 15:54
categories: [post, antarctica]
---

[![Sundowner screenshot](/img/posts/sundowner.jpg)][1]

With short days and limited daylight, it's useful to have accurate times for dawn and dusk. I've been playing around with [PyEphem][2] and [Flask][3] to build [Sundowner][1] – a simple web app for calculating sunrise, sunset, and civil dawn and dusk[^1] for different locations.

The source can be found on [GitHub][4], and can be installed from [PyPi][5]. I'm running the [proof-of-concept][1] with [nginx][6] and [uWSGI][7].

[^1]: Civil dawn/dusk is when the sun is 6º below the horizon – essentially when there's enough light to travel safely.

[1]: https://porthos.kenners.org/sundowner
[2]: http://rhodesmill.org/pyephem
[3]: http://flask.pocoo.org
[4]: https://github.com/kenners/sundowner
[5]: https://pypi.python.org/pypi/Sundowner
[6]: http://nginx.org
[7]: http://uwsgi-docs.readthedocs.org
