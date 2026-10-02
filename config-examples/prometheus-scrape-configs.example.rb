prometheus['scrape_configs'] = [
  {
    'job_name' => '<SERVER>-node',
    'scrape_interval' => '15s',
    'static_configs' => [
      {
        'targets' => ['<SERVER-IP>:9100'],
        'labels' => {
          'server' => '<SERVER>',
          'environment' => '<ENVIRONMENT>'
        }
      }
    ]
  },
  {
    'job_name' => '<SERVER>-https',
    'scrape_interval' => '30s',
    'scrape_timeout' => '15s',
    'metrics_path' => '/probe',
    'params' => {
      'module' => ['<BLACKBOX-MODULE>']
    },
    'static_configs' => [
      {
        'targets' => [
          'https://<SERVER-DOMAIN>/'
        ],
        'labels' => {
          'server' => '<SERVER>',
          'service' => '<SERVICE>'
        }
      }
    ],
    'relabel_configs' => [
      {
        'source_labels' => ['__address__'],
        'target_label' => '__param_target'
      },
      {
        'source_labels' => ['__param_target'],
        'target_label' => 'instance'
      },
      {
        'target_label' => '__address__',
        'replacement' => '127.0.0.1:9115'
      }
    ]
  }
]