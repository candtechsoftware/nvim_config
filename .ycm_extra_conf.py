# Fallback YCM config for projects without their own .ycm_extra_conf.py
def Settings(**kwargs):
    return {
        'flags': [
            '-x', 'c',
            '-std=c11',
            '-I', '.',
            '-I', 'src',
            '-I', 'code',
            '-Wno-everything',  # Disable all warnings
        ],
    }
