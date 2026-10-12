#pragma once

#include <ament_index_cpp/get_package_share_directory.hpp>
#include <filesystem>
#include <string>

namespace sledgehammer {
inline std::string data_path(const std::string& name, const std::string& root) {
  const std::filesystem::path path(name);
  return (path.is_absolute() ? path : std::filesystem::path(root) / path).string();
}
}  // namespace sledgehammer
