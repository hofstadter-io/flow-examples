package concurrency

import (
  "list"
)

mailbox: "messages"

main: {
  @flow(csp/basic)

  m: { "mailbox": mailbox, buf: 10, done: _ } @task(csp.Chan)
  c: consumer & { dep: m.done }
  p: producer & { dep: m.done }
}

producer: { 
  M: 10
  N: 10
  msgs: list.FlattenN([
    for m in list.Range(0,M,1) {[
      for n in list.Range(0,N,1) {
        "msg:\(m)-\(n)"
      }
    ]}
  ], 1)

  wait: { duration: "2s", done: _ } @task(os.Sleep)

  for i,msg in msgs {
    "t\(i)": {
      dep: wait.done
      @task(csp.Send)
      "mailbox": mailbox 
      val: { text: msg }
    }
  }
}

consumer: {
  N: 3

  for n,_ in list.Range(0,N,1) {
    "c-\(n)": {
      @task(csp.Recv)
      "mailbox": mailbox
      handler: {
        msg: _
        print: {
          @task(os.Stdout)
          text: msg.val.text + " -> C\(n)\n"
          done: _
        }

        sleep: { duration: "1s" } @task(os.Sleep)
      }
    }
  }
}
