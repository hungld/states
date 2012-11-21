include:
  - diamond
  - nrpe

{# TODO: use elasticsearch as gid and uid #}

/etc/default/elasticsearch:
  file:
    - managed
    - template: jinja
    - user: root
    - group: root
    - mode: 644
    - source: salt://elasticsearch/default.jinja2
    - require:
      - pkg_file: elasticsearch

/etc/elasticsearch/logging.yml:
  file:
    - managed
    - template: jinja
    - user: root
    - group: elasticsearch
    - mode: 640
    - source: salt://elasticsearch/logging.jinja2
    - require:
      - pkg_file: elasticsearch

/etc/cron.daily/elasticsearch-cleanup:
  file:
    - managed
    - template: jinja
    - user: root
    - group: root
    - mode: 755
    - source: salt://elasticsearch/cron_daily.jinja2

elasticsearch:
  pkg:
    - installed
    - name: openjdk-7-jre-headless
  elasticsearch_plugins:
    - installed
    - name: cloud-aws
    - url: elasticsearch/elasticsearch-cloud-aws/{{ pillar['elasticsearch']['elasticsearch-cloud-aws_version'] }}
  pkg_file:
    - installed
    - name: elasticsearch
    - version: {{ pillar['elasticsearch']['version'] }}
    - address: https://github.com/downloads/elasticsearch/elasticsearch/elasticsearch-{{ pillar['elasticsearch']['version'] }}.deb
    - hash: md5={{ pillar['elasticsearch']['md5'] }}
    - require:
      - pkg: elasticsearch
  file:
    - managed
    - name: /etc/elasticsearch/elasticsearch.yml
    - template: jinja
    - user: root
    - group: elasticsearch
    - mode: 640
    - source: salt://elasticsearch/config.jinja2
    - require:
      - pkg_file: elasticsearch
  service:
    - running
    - watch:
      - file: /etc/default/elasticsearch
      - file: /etc/elasticsearch/logging.yml
      - file: elasticsearch
      - pkg_file: elasticsearch
      - pkg: elasticsearch
      - elasticsearch_plugins: elasticsearch

/etc/nagios/nrpe.d/elasticsearch.cfg:
  file:
    - managed
    - template: jinja
    - user: nagios
    - group: nagios
    - mode: 600
    - source: salt://elasticsearch/nrpe.jinja2

/usr/local/bin/check_elasticsearch_cluster.py:
  file:
    - managed
    - source: salt://elasticsearch/check.py
    - mode: 755
    - require:
      - pip: nagios-nrpe-server

elasticsearch_diamond_collector:
  file:
    - managed
    - name: /etc/diamond/collectors/ElasticSearchCollector.conf
    - template: jinja
    - user: root
    - group: root
    - mode: 600
    - source: salt://elasticsearch/diamond.jinja2

extend:
  diamond:
    service:
      - watch:
        - file: elasticsearch_diamond_collector
  nagios-nrpe-server:
    service:
      - watch:
        - file: /etc/nagios/nrpe.d/elasticsearch.cfg