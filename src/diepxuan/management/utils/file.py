import unicodedata
import re
from . import register_command


def remove_vietnamese_diacritics(text):
    # Chuẩn hóa Unicode
    nfkd_form = unicodedata.normalize("NFKD", text)
    # Loại bỏ dấu
    no_diacritics = "".join([c for c in nfkd_form if not unicodedata.combining(c)])
    return no_diacritics


def filename_clean(filename):
    # Chuyển không dấu
    filename = remove_vietnamese_diacritics(filename)
    # Thay \ bằng khoảng trắng (tùy chọn)
    filename = filename.replace("\\", " ")
    # Loại bỏ khoảng trắng dư thừa
    filename = re.sub(r"\s+", " ", filename)
    # Loại bỏ khoảng trắng đầu cuối
    filename = filename.strip()
    # Loại bỏ khoảng trắng và _ ngay sau |
    filename = re.sub(r"(\|)[\s_]+", r"\1", filename)
    # Chuyển khoảng trắng thành dấu _
    filename = filename.replace(" ", "_")
    return filename


@register_command
def d_file_cleanpath(paths):
    """
    Đổi tên file:
    - Chuyển không dấu
    - Thay khoảng trắng bằng dấu gạch dưới
    - Giữ nguyên các thư mục
    """
    from pathlib import Path

    for path in paths:
        p = Path(path)
        new_name = filename_clean(p.name)
        new_path = p.with_name(new_name)

        try:
            p.rename(new_path)
            return str(new_path)
        except FileNotFoundError:
            print(f"File '{p}' không tồn tại!")
        except Exception as e:
            print(f"Lỗi: {e}")
            print(filename_clean(path))


# Ví dụ
# filename = r"TA\ TẬN\ THẾ\ NUÔI\ NỮ\ THẦN｜\ PHẦN\ FULL\ END\ 89\ TIẾNG\ [K5x9R_3wZeQ]2.mp3"
# new_filename = clean_filename(filename)
# print(new_filename)
