command: "bash -c 'python3 $HOME/Desktop/reading-widget/update.py >/dev/null 2>&1; cat $HOME/Desktop/reading-widget/widget-fragment.html'"

refreshFrequency: 300000

render: (output) -> output

style: """
  top: 40px
  left: 40px
"""
