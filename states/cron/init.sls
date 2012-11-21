include:
  - nrpe

cron:
  pkg:
    - installed
  file:
    - managed
    - name: /etc/crontab
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - source: salt://cron/crontab.jinja2
    - require:
      - pkg: cron
  service:
    - running
    - watch:
      - pkg: cron
      - file: /etc/crontab

/etc/nagios/nrpe.d/cron.cfg:
  file.managed:
    - template: jinja
    - user: nagios
    - group: nagios
    - mode: 600
    - source: salt://cron/nrpe.jinja2

extend:
  nagios-nrpe-server:
    service:
      - watch:
        - file: /etc/nagios/nrpe.d/cron.cfg