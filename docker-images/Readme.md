...Serf events glue together all the parts of seaworthy making a cluster interact as a whole system...

There are handler specific to be used in machines with differente roles (waypoints, ferries or harbors) and there is a series of event handler common to them all.


Extended version of hull that includes admin oriented stuff like serf, and geard

https://github.com/openshift/geard/blob/b7fbcf1776332f40505cdc26ef6316005b765d48/contrib/geard-image.service

    docker run -i -t vlipco/harbor /bin/bashi
    docker run -i -t vlipco/harbor /bin/bashi

    serf agent -join 10.0.2.15 -bind 0.0.0.0:7946 -advertise 10.0.2.15:..