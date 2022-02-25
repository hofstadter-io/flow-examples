package concurrency

import "list"

// demonstrates limiting a task to
// at most N concurrent processors
poolExample: {
  @flow(pool/exec)

  init: {
    @task(noop)
    @pool(api,2)
  }

  for i,_ in list.Range(0,5,1) {
    let I = i
    "task-\(I)": {
      @task(nest)
      @pool(api)
      call: {
        @task(api.Call)
        req: {
          host: "https://postman-echo.com"
          method: "GET"
          path: "/get"
          query: {
            cow: "moo"
            task: "\(I)"
          }
        }
        resp: string
      }
      out: { text: call.resp + "\n"} @task(os.Stdout)
      wait: { duration: "1s", dep: [call,out] } @task(os.Sleep)
    }

  }
}

