void console_print_char(byte char);
void console_print_chars(byte n, byte* chars);
void console_print(byte* string);
void console_print_byte(byte b);
void console_print_word(word b);
void console_print_address(byte* b);
void console_new_line();

void debug_print_char(byte char);
void debug_print_chars(byte n, byte* chars);
void debug_print(byte* string);
void debug_print_byte(byte b);
void debug_print_word(word b);
void debug_print_address(byte* b);
void debug_new_line();

word word_of_bytes(byte l,byte h);
word srl_word(word w);
word sla_word(word w);

void int32_of_byte(byte* i, byte b);
void int32_of_word(byte* i, word a);
void int32_of_int32(byte* i, byte* j);
void int32_add_byte(byte* i, byte b);
void int32_add_word(byte* i, word a);
void int32_add_int32(byte* a, byte* b);
bool int32_is_equal(byte* a,byte* b);
void int32_srl(byte* a);
void int32_sla(byte* a);
void int32_print(byte* a);
void int32_debug(byte* a);

bool sd_init();
bool sd_load_sector(byte* target, byte* sector);

byte[0x200] fat_buffer;
byte[0x200] data_buffer;
byte[0x1000] directory_buffer;

bool fat32;
byte sectors_per_cluster;
byte[4] first_fat_sector;
byte[4] first_data_sector;
byte[4] current_data_sector;
byte[4] current_fat_sector;
byte[4] root_directory;
word root_directory_size;

bool fat_init()
{
	byte[4] sector;
	byte tmp;

	int32_of_byte(sector, 0);
	if (!sd_load_sector(data_buffer, sector)) {
		console_print("error while loading mbr");
		console_new_line();
		return false;
	}

	if ((data_buffer[0x1fe]!=0x55) || (data_buffer[0x1ff]!=0xaa)) {
		console_print("wrong mbr");
		console_new_line();
		return false;
	}

	tmp = data_buffer[0x1c2];
	if (tmp == 0x06) {
		fat32 = false;
	} else {
	if (tmp == 0x0b) {
		fat32 = true;
	} else {
		console_print("unknown filesystem type (fat16/32 only)");
		console_new_line();
		return false;
	}}

	int32_of_int32(sector, &data_buffer[0x1c6]);
//	console_print("first sector: ");
//	int32_print(sector);
//	console_new_line();
	
	if (!sd_load_sector(data_buffer, sector)) {
		console_print("error while loading boot sector");
		console_new_line();
		return false;
	}

	if ((data_buffer[0x1fe]!=0x55) || (data_buffer[0x1ff]!=0xaa)) {
		console_print("wrong boot record");
		console_new_line();
		return false;
	}

	if ((data_buffer[11]!=0) || (data_buffer[12]!=2)) {
		console_print("sector size != 0x200");
		console_new_line();
		return false;
	}

	sectors_per_cluster = data_buffer[13];

	int32_of_int32(first_fat_sector, sector);
	int32_add_byte(first_fat_sector, data_buffer[14]);	// reserved sectors

	if (fat32) {
		fat_init32();
	} else {
		fat_init16();
	}

//	console_print("first data sector: ");
//	int32_print(first_data_sector);
//	console_new_line();

//	console_print("root directory: ");
//	int32_print(root_directory);
//	console_new_line();
	return true;
}

void fat_init32()
{
	int32_of_int32(first_data_sector, first_fat_sector);
	repeat (data_buffer[16]) {				// # of FATs
		int32_add_int32(first_data_sector, &data_buffer[36]);
	}
	int32_of_int32(root_directory, &data_buffer[0x2c]);
}

void fat_init16()
{
	word fat_size;

	// root directory first sector
	int32_of_int32(root_directory, first_fat_sector);
	fat_size = word_of_bytes(data_buffer[22], data_buffer[23]);
	repeat (data_buffer[16]) {				// # of FATs
		int32_add_word(root_directory, fat_size);
	}

	// root directory size (in sectors)
	root_directory_size = word_of_bytes(data_buffer[17], data_buffer[18]);
	repeat (4) {						// divide by 0x10
		root_directory_size = srl_word(root_directory_size);
	}

	// first data sector = first sector after root directory
	int32_of_int32(first_data_sector, root_directory);
	int32_add_word(first_data_sector, root_directory_size);
}

bool load_fat_sector(byte* s)
{
	byte[4] sector;

	if (int32_is_equal(s, current_fat_sector)) {
		return true;
	}

	int32_of_int32(sector, first_fat_sector);
	int32_add_int32(sector,s);
	if (sd_load_sector(fat_buffer, sector)) {
		int32_of_int32(current_fat_sector, s);
		return true;
	}
	return false;
}

bool load_data_sector(byte* sector)
{
	if (int32_is_equal(sector, current_data_sector)) {
		return true;
	}

	if (sd_load_sector(data_buffer, sector)) {
		int32_of_int32(current_data_sector, sector);
		return true;
	}
	return false;
}

void first_sector_of_cluster(byte* sector, byte* cluster)
{
	byte[4] minus2;
	minus2[0] = 0xfe;
	minus2[1] = 0xff;
	minus2[2] = 0xff;
	minus2[3] = 0xff;

	int32_of_int32(sector, first_data_sector);
	repeat(sectors_per_cluster) {
		int32_add_int32(sector,minus2);
		int32_add_int32(sector,cluster);
	}
}

bool fat_next_cluster(byte* next, byte* current)
{
	byte[4] fat_sector;
	word offset;

	int32_of_int32(fat_sector, current);
	repeat (7) {
		int32_srl(fat_sector);
	}
	if (!load_fat_sector(fat_sector)) {
		return false;
	}

	offset = current[0] & 0x7f;
	offset = offset+offset;
	offset = offset+offset;

	int32_of_int32(next, &fat_buffer[offset]);
	return true;
}

bool fat_is_last_cluster(byte* cluster)
{
	if ((cluster[0]&0xf8)!=0xf8) {
		return false;
	}
	if (cluster[1]!=0xff) {
		return false;
	}
	if (cluster[2]!=0xff) {
		return false;
	}
	if (cluster[3]!=0xff) {
		return false;
	}
	return true;
}

bool fat_open_root_directory()
{
	if (fat32) {
		return fat_open_directory(root_directory);
	}
	return fat_open_root_directory16();
}

bool fat_open_root_directory16()
{
	byte[4] sector;
	byte* directory_ptr;
	byte* buffer_ptr;

	fat_clear_directory_buffer();

	int32_of_int32(sector,root_directory);
	directory_ptr = directory_buffer;
	repeat (root_directory_size) {
		if (!load_data_sector(sector)) {
			return false;
		}
		if (process_directory_sector(&directory_ptr,data_buffer)) {
			return true;
		}
		int32_add_byte(sector,1);
	}
	*directory_ptr = 0;
	return true;
}

bool fat_open_directory(byte* first_cluster)
{
	byte[4] cluster;
	byte[4] sector;
	byte* directory_ptr;

	if (!fat32) {
		int32_of_byte(cluster,0);
		if (int32_is_equal(first_cluster,cluster)) {
			console_print("root");
			console_new_line();
			return fat_open_root_directory16();
		}
	}

	fat_clear_directory_buffer();

	int32_of_int32(cluster, first_cluster);
	directory_ptr = directory_buffer;
	do {
		first_sector_of_cluster(sector,cluster);
		repeat(8) {
			if (!load_data_sector(sector)) {
				return false;
			}
			if (process_directory_sector(&directory_ptr,data_buffer)) {
				return true;
			}
			int32_add_byte(sector,1);
		}
		if (fat_next_cluster(cluster,cluster)) {
			return false;
		}
	} while (!fat_is_last_cluster(cluster));
	return true;
}

bool process_directory_sector(byte** directory_ptr,byte* buffer_ptr)
{
	repeat (0x10) {
		if ((*buffer_ptr) == 0) {
			return true;
		}
		if (fat_process_directory_entry(*directory_ptr, buffer_ptr)) {
			*directory_ptr = (*directory_ptr) + 0x10;
		}
		buffer_ptr = buffer_ptr + 0x20;
	}
	return false;
}

void fat_clear_directory_buffer()
{
	byte* a;
	a = directory_buffer;
	repeat(0x100) {
		*a = 0;
		a = a+0x10;
	}
}

bool fat_process_directory_entry(byte* target, byte* data)
{
	byte* src;
	byte* dst;

	if ((*data) == 0xe5) {		// deleted
		return false;
	} 
	if ((data[11]&13) != 0) {	// fancy attributes
		return false;
	}

	// first byte : directories are 0x01", files are 0x11
	*target = ((data[11]&0x10)^0x10) | 0x01;
	target = target+1;

	// copy file name (11 bytes)
	repeat(11) {
		*target = *data;
		target = target+1;
		data = data+1;
	}

	// copy cluster # (4 bytes)
	target[0] = data[15];
	target[1] = data[16];
	if (fat32) {
		target[2] = data[ 9];
		target[3] = data[10];
	} else {
		target[2] = 0;
		target[3] = 0;
	}

	return true;
}




