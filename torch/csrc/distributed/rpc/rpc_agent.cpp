#include <torch/csrc/distributed/rpc/rpc_agent.h>

namespace torch {
namespace distributed {
namespace rpc {

RpcAgent::RpcAgent(std::string workerName, RequestCallback cb)
    : workerName_(std::move(workerName)), cb_(std::move(cb)) {}

RpcAgent::~RpcAgent() = default;

}
}
}
