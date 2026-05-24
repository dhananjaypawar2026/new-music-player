#ifndef RUNNER_UTILS_H_
#define RUNNER_UTILS_H_

#include <optional>
#include <string>
#include <vector>

struct StoredWindowSize {
    int width;
    int height;
    // True when the stored values represent physical pixels, false for logical
    // coordinates.
    bool is_physical;
};

// Creates a console for the process, and redirects stdout and stderr to
// it for both the runner and the Flutter library.
void CreateAndAttachConsole();

// Takes a null-terminated wchar_t* encoded in UTF-16 and returns a std::string
// encoded in UTF-8. Returns an empty std::string on failure.
std::string Utf8FromUtf16(const wchar_t* utf16_string);

// Gets the command line arguments passed in as a std::vector<std::string>,
// encoded in UTF-8. Returns an empty std::vector<std::string> on failure.
std::vector<std::string> GetCommandLineArguments();

// Loads the last saved window size, if present.
std::optional<StoredWindowSize> LoadStoredWindowSize();

// Persists the provided window size for future runs.
void SaveWindowSize(const StoredWindowSize& size);

#endif  // RUNNER_UTILS_H_
