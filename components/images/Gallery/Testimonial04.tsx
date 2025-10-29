/* auto-generated; do not edit */
import React from 'react';
import src from '../../assets/testimonial-04.webp';
type Props = Omit<React.ImgHTMLAttributes<HTMLImageElement>, 'src' | 'alt'> & { alt?: string };
export default function Testimonial04({ alt, ...rest }: Props) {
  return (
    <img
      src={String(src)}
      alt={alt ?? 'Testimonial 04'}
      loading="lazy"
      decoding="async"
      {...rest}
    />
  );
}
