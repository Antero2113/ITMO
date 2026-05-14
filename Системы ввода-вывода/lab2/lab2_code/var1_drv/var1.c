#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/cdev.h>
#include <linux/device.h>
#include <linux/uaccess.h>
#include <linux/slab.h>

#define DEVICE_NAME "var1"
#define CLASS_NAME "var1_class"

static int major;
static struct class *var1_class;
static struct device *var1_device;
static struct cdev var1_cdev;

static int *results;
static int count;
static int capacity;

static int var1_open(struct inode *inode, struct file *file)
{
    return 0;
}

static int var1_release(struct inode *inode, struct file *file)
{
    return 0;
}

static ssize_t var1_write(struct file *file, const char __user *buf, size_t len, loff_t *off)
{
    int *new_results;
    int new_count;

    new_count = count + 1;

    if (new_count > capacity) {
        capacity = capacity == 0 ? 8 : capacity * 2;
        new_results = krealloc(results, capacity * sizeof(int), GFP_KERNEL);
        if (!new_results)
            return -ENOMEM;
        results = new_results;
    }

    results[count] = len;
    count++;

    return len;
}

static ssize_t var1_read(struct file *file, char __user *buf, size_t len, loff_t *off)
{
    char *kbuf;
    int i, pos = 0;
    int size = 0;

    if (*off > 0)
        return 0;

    for (i = 0; i < count; i++)
        size += 20;

    kbuf = kmalloc(size + 1, GFP_KERNEL);
    if (!kbuf)
        return -ENOMEM;

    for (i = 0; i < count; i++)
        pos += sprintf(kbuf + pos, "%d\n", results[i]);

    if (copy_to_user(buf, kbuf, pos)) {
        kfree(kbuf);
        return -EFAULT;
    }

    kfree(kbuf);
    *off = pos;

    return pos;
}

static struct file_operations fops =
{
    .open = var1_open,
    .release = var1_release,
    .read = var1_read,
    .write = var1_write,
};

static int __init var1_init(void)
{
    dev_t dev;

    alloc_chrdev_region(&dev, 0, 1, DEVICE_NAME);
    major = MAJOR(dev);

    cdev_init(&var1_cdev, &fops);
    cdev_add(&var1_cdev, dev, 1);

    var1_class = class_create(THIS_MODULE, CLASS_NAME);
    var1_device = device_create(var1_class, NULL, dev, NULL, DEVICE_NAME);

    results = NULL;
    count = 0;
    capacity = 0;

    return 0;
}

static void __exit var1_exit(void)
{
    dev_t dev = MKDEV(major, 0);

    device_destroy(var1_class, dev);
    class_destroy(var1_class);
    cdev_del(&var1_cdev);
    unregister_chrdev_region(dev, 1);

    kfree(results);
}

module_init(var1_init);
module_exit(var1_exit);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Student");
MODULE_DESCRIPTION("Variant 1 char device");